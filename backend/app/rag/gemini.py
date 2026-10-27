"""
Accès à l'API Gemini de Google AI Studio (tâche P5.4, ADR-011).

Le moteur de conseil ne dépend que du protocole ClientLlm : les tests lui
passent un faux client, sans réseau ni clé.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Literal, Protocol

TypeTache = Literal["question", "document"]

# Quota Google ou panne passagère (dont 504 « deadline expired », vu en
# évaluation) : les scripts hors ligne réessaient, l'endpoint répond 503.
CODES_A_REESSAYER = frozenset({429, 500, 502, 503, 504})


class ErreurFournisseur(Exception):
    """L'API Gemini n'a pas répondu : clé refusée, quota Google, réseau ou délai dépassé."""

    def __init__(self, message: str, code: int | None = None) -> None:
        super().__init__(message)
        self.code = code


@dataclass(frozen=True)
class Generation:
    texte: str
    jetons_entree: int | None = None
    jetons_sortie: int | None = None


class ClientLlm(Protocol):
    def vectoriser(self, textes: list[str], *, type_tache: TypeTache) -> list[list[float]]: ...

    def generer(self, *, consigne: str, message: str) -> Generation: ...


# --- Conversation avec outils (agent, ADR-012) ---

@dataclass(frozen=True)
class DeclarationOutil:
    nom: str
    description: str
    parametres: dict


@dataclass(frozen=True)
class AppelOutil:
    nom: str
    arguments: dict


@dataclass
class Message:
    role: Literal["utilisateur", "modele", "outil"]
    texte: str = ""
    # Contenu du modèle tel que l'API l'a renvoyé : les modèles Gemini 3 exigent
    # qu'on leur rende leurs « signatures de pensée » avec les appels d'outils.
    brut: Any = None
    resultats: list[tuple[str, dict]] = field(default_factory=list)


@dataclass(frozen=True)
class TourModele:
    texte: str
    appels: list[AppelOutil]
    brut: Any = None
    jetons_entree: int | None = None
    jetons_sortie: int | None = None


class ClientAgent(ClientLlm, Protocol):
    def converser(
        self,
        *,
        consigne: str,
        messages: list[Message],
        outils: list[DeclarationOutil],
        autoriser_outils: bool,
    ) -> TourModele: ...


class ClientGemini:
    def __init__(
        self,
        *,
        cle_api: str,
        modele_generation: str,
        modele_embedding: str,
        dimensions: int,
        delai_secondes: int,
        max_jetons_reponse: int,
    ) -> None:
        from google import genai
        from google.genai import types

        self._types = types
        self._client = genai.Client(
            api_key=cle_api,
            http_options=types.HttpOptions(timeout=delai_secondes * 1000),
        )
        self._modele_generation = modele_generation
        self._modele_embedding = modele_embedding
        self._dimensions = dimensions
        self._max_jetons_reponse = max_jetons_reponse

    def vectoriser(self, textes: list[str], *, type_tache: TypeTache) -> list[list[float]]:
        config = self._types.EmbedContentConfig(
            task_type="RETRIEVAL_QUERY" if type_tache == "question" else "RETRIEVAL_DOCUMENT",
            output_dimensionality=self._dimensions,
        )
        reponse = self._appeler(
            lambda: self._client.models.embed_content(
                model=self._modele_embedding, contents=textes, config=config
            )
        )
        vecteurs = [list(embedding.values) for embedding in reponse.embeddings or []]
        if len(vecteurs) != len(textes):
            raise ErreurFournisseur(f"{len(vecteurs)} vecteurs reçus pour {len(textes)} textes")
        return vecteurs

    def generer(self, *, consigne: str, message: str) -> Generation:
        config = self._types.GenerateContentConfig(
            system_instruction=consigne,
            temperature=0.2,
            max_output_tokens=self._max_jetons_reponse,
        )
        reponse = self._appeler(
            lambda: self._client.models.generate_content(
                model=self._modele_generation, contents=message, config=config
            )
        )
        usage = reponse.usage_metadata
        return Generation(
            texte=reponse.text or "",
            jetons_entree=usage.prompt_token_count if usage else None,
            jetons_sortie=usage.candidates_token_count if usage else None,
        )

    def converser(
        self,
        *,
        consigne: str,
        messages: list[Message],
        outils: list[DeclarationOutil],
        autoriser_outils: bool,
    ) -> TourModele:
        types = self._types
        contenus = []
        for message in messages:
            if message.role == "utilisateur":
                contenus.append(types.Content(role="user", parts=[types.Part.from_text(text=message.texte)]))
            elif message.role == "modele":
                contenus.append(
                    message.brut
                    if message.brut is not None
                    else types.Content(role="model", parts=[types.Part.from_text(text=message.texte)])
                )
            else:
                # L'API Gemini Developer refuse le rôle « tool » (400), malgré la
                # documentation du SDK : les réponses d'outils passent en « user ».
                contenus.append(
                    types.Content(
                        role="user",
                        parts=[
                            types.Part.from_function_response(name=nom, response=resultat)
                            for nom, resultat in message.resultats
                        ],
                    )
                )
        # Les déclarations restent présentes même quand les appels sont interdits :
        # l'historique peut contenir des appels auxquels le modèle doit se référer.
        config = types.GenerateContentConfig(
            system_instruction=consigne,
            temperature=0.2,
            max_output_tokens=self._max_jetons_reponse,
            tools=[
                types.Tool(
                    function_declarations=[
                        types.FunctionDeclaration(
                            name=outil.nom,
                            description=outil.description,
                            parameters_json_schema=outil.parametres,
                        )
                        for outil in outils
                    ]
                )
            ],
            tool_config=types.ToolConfig(
                function_calling_config=types.FunctionCallingConfig(
                    mode="VALIDATED" if autoriser_outils else "NONE"
                )
            ),
            automatic_function_calling=types.AutomaticFunctionCallingConfig(disable=True),
        )
        reponse = self._appeler(
            lambda: self._client.models.generate_content(
                model=self._modele_generation, contents=contenus, config=config
            )
        )
        candidat = reponse.candidates[0] if reponse.candidates else None
        parties = (candidat.content.parts or []) if candidat and candidat.content else []
        texte = "".join(p.text for p in parties if p.text and not getattr(p, "thought", False))
        usage = reponse.usage_metadata
        return TourModele(
            texte=texte,
            appels=[
                AppelOutil(nom=appel.name or "", arguments=dict(appel.args or {}))
                for appel in reponse.function_calls or []
            ],
            brut=candidat.content if candidat else None,
            jetons_entree=usage.prompt_token_count if usage else None,
            jetons_sortie=usage.candidates_token_count if usage else None,
        )

    @staticmethod
    def _appeler(appel):
        import httpx
        from google.genai import errors

        try:
            return appel()
        except errors.APIError as erreur:
            raise ErreurFournisseur(f"API Gemini : {erreur.code} {erreur.message}", erreur.code) from erreur
        except httpx.HTTPError as erreur:
            raise ErreurFournisseur(f"réseau : {type(erreur).__name__}") from erreur

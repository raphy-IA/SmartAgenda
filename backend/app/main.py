from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
import traceback

print("🚀 SERVER STARTING - PORT 8001 PREPARATION...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Config CORS (Indispensable pour Flutter Web)
# Utilisation de allow_origin_regex pour autoriser TOUTES les origines (localhost:*, 127.0.0.1:*, etc.)
# tout en supportant allow_credentials=True
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex="https?://.*", # Autorise http:// et https:// suivi de n'importe quoi
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# DEBUG: Handler Global pour capturer les 500 et afficher la trace

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    error_msg = f"❌ CRITICAL SERVER ERROR: {str(exc)}\n{traceback.format_exc()}"
    print(error_msg) # Affiche dans la console Backend
    return JSONResponse(
        status_code=500,
        content={"message": "Internal Server Error", "detail": str(exc)},
    )

from app.api.v1.endpoints import events, voice, categories

app.include_router(events.router, prefix=f"{settings.API_V1_STR}/events", tags=["events"])
app.include_router(voice.router, prefix=f"{settings.API_V1_STR}/voice", tags=["voice"])
app.include_router(categories.router, prefix=f"{settings.API_V1_STR}/categories", tags=["categories"])

@app.get("/")
async def root():
    return {"message": "Welcome to SmartAgenda AI API", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "ok"}

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "SmartAgenda AI API"
    API_V1_STR: str = "/api/v1"
    
    # Supabase
    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""
    
    # AI Configuration
    # Provider options: "openai", "gemini", "deepseek" (future), "mock"
    LLM_PROVIDER: str = "mock" 
    
    # OpenAI
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-4o"

    # Google Gemini
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-1.5-flash"

    # Groq (Llama 3)
    GROQ_API_KEY: str = ""

    class Config:
        env_file = ".env"

settings = Settings()

from fastapi import APIRouter, Depends
from typing import List
from app.core.database import db
from pydantic import BaseModel

router = APIRouter()

class CategoryRead(BaseModel):
    id: str
    name: str
    color_hex: str
    priority_level: int = 5
    is_default: bool = False

@router.get("/", response_model=List[CategoryRead])
def list_categories():
    """
    Récupère toutes les catégories disponibles pour l'application mobile.
    """
    try:
        response = db.table("categories").select("*").execute()
        return response.data
    except Exception as e:
        print(f"❌ Error fetching categories: {e}")
        # Fallback Mock si la DB est vide ou inaccessible
        return [
            {"id": "mock-1", "name": "Travail", "color_hex": "#2196F3"},
            {"id": "mock-2", "name": "Personnel", "color_hex": "#4CAF50"},
            {"id": "mock-3", "name": "Santé", "color_hex": "#F44336"},
            {"id": "mock-4", "name": "Sport", "color_hex": "#E91E63"},
        ]

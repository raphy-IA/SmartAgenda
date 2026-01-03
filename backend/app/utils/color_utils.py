import hashlib

def generate_color_from_text(text: str) -> str:
    """
    Génère une couleur HEX cohérente et visible (pas trop sombre/claire) 
    à partir d'une chaîne de texte (Seed).
    """
    if not text:
        return "#9E9E9E" # Default Grey
        
    # Hash MD5 du texte pour avoir une consistance (Même texte = Même couleur)
    hash_object = hashlib.md5(text.lower().encode())
    hash_hex = hash_object.hexdigest()
    
    # On prend les 6 premiers caractères du hash
    # Mais on veut éviter les couleurs trop sombres ou trop pâles.
    # Astuce HSV serait mieux, mais Hash simple + Saturation forcée est plus simple.
    
    r = int(hash_hex[0:2], 16)
    g = int(hash_hex[2:4], 16)
    b = int(hash_hex[4:6], 16)
    
    # Boost brightness/saturation if too dark
    # Simple clamp: Ensure at least one channel is high
    if max(r, g, b) < 100:
        r = min(255, r + 100)
        g = min(255, g + 100)
        b = min(255, b + 100)
        
    return f"#{r:02x}{g:02x}{b:02x}".upper()

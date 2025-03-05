import os

def create_file(file_name, file_type, content=None):
    try:
        if file_type == "com":
            with open(file_name + ".com", "w") as f:
                f.write(content if content else "X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*")

        elif file_type == "exe":
            with open(file_name + ".exe", "wb") as f:
                f.write(b"MZ")  # Signature d'un fichier exécutable Windows

        elif file_type == "json":
            with open(file_name + ".json", "w") as f:
                f.write(content if content else "{}")

        elif file_type == "png":
            with open(file_name + ".png", "wb") as f:
                f.write(b"\x89PNG\r\n\x1a\n")  # Signature d'un fichier PNG

        elif file_type == "html":
            with open(file_name + ".html", "w") as f:
                f.write("<html><body><h1>Page HTML créée</h1></body></html>")
        
        elif file_type == "bat":
            with open(file_name + ".bat", "w") as f:
                f.write("@echo off\necho Script batch créé")

        elif file_type == "sh":
            with open(file_name + ".sh", "w") as f:
                f.write("#!/bin/bash\necho 'Script shell créé'")
            os.chmod(file_name + ".sh", 0o755)  # Rendre le script exécutable

        else:
            print("Type de fichier non supporté.")
            return

        print(f"Fichier {file_name}.{file_type} créé avec succès!")
    except Exception as e:
        print(f"Erreur lors de la création du fichier: {e}")

# Exemples d'utilisation
types_de_fichiers = ["com", "exe", "json", "png", "html", "bat", "sh"]
for t in types_de_fichiers:
    create_file("exemple", t)

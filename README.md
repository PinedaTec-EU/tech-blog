# Tech Blog

Repositorio para publicar articulos tecnicos sobre herramientas de integracion,
automatizacion y desarrollo, incluyendo Sphere Integration Hub.

## Desarrollo local

MkDocs esta instalado en este equipo, pero el ejecutable quedo en:

```sh
/Users/jmr.pineda/Library/Python/3.9/bin/mkdocs
```

Puedes ejecutarlo sin cambiar el `PATH` con:

```sh
python3 -m mkdocs serve
```

O anadir los scripts de Python de usuario a tu shell:

```sh
echo 'export PATH="$HOME/Library/Python/3.9/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
mkdocs --version
```

Comandos utiles:

```sh
python3 -m mkdocs serve
python3 -m mkdocs build
```

## Deployment

El sitio se publica en GitHub Pages mediante GitHub Actions.

El workflow esta en:

```sh
.github/workflows/deploy-pages.yml
```

Se ejecuta automaticamente al hacer push a `main` y tambien se puede lanzar manualmente desde la pestana Actions.

# Tech Blog

Repository for publishing technical articles about integration, automation, and
software development tools, including Sphere Integration Hub.

## Content Conventions

Public articles must be written in English, including titles, descriptions,
navigation labels, article cards, and social preview metadata.

## Local Development

MkDocs is installed on this machine, but the executable is located at:

```sh
/Users/jmr.pineda/Library/Python/3.9/bin/mkdocs
```

You can run it without changing `PATH` with:

```sh
python3 -m mkdocs serve
```

Or add the user Python scripts directory to your shell:

```sh
echo 'export PATH="$HOME/Library/Python/3.9/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
mkdocs --version
```

Useful commands:

```sh
python3 -m mkdocs serve
python3 -m mkdocs build
```

## Deployment

The site is published to GitHub Pages through GitHub Actions.

The workflow is located at:

```sh
.github/workflows/deploy-pages.yml
```

It runs automatically on pushes to `main` and can also be triggered manually from the Actions tab.

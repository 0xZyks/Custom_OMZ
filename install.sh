# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    install.sh                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tsignori <tsignori@student.42perpignan.fr  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/12/05 11:26:33 by tsignori          #+#    #+#              #
#    Updated: 2025/12/05 11:48:43 by tsignori         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

ZSHRC_SRC="$SCRIPT_DIR/zsh_config"
ZSH_DIR_SRC="$SCRIPT_DIR/zsh"

ZSHRC_DEST="$HOME/.zshrc"
ZSH_DIR_DEST="$HOME/.config/zsh"

# -------- MENU FLECHES --------
choose_with_arrows() {
  local n __result=$1
  shift
  local options=("$@")
  local index=0
  local key

  while true; do
    clear
    echo "Voulez-vous sauvegarder votre ancienne config ?"
    echo

    for i in "${!options[@]}"; do
      if [[ $i -eq $index ]]; then
        printf " > %s\n" "${options[$i]}"
      else
        printf "   %s\n" "${options[$i]}"
      fi
    done

    # On lit 1 touche
    read -rsn1 key

    # Entrée → on valide
    if [[ $key == "" ]]; then
      __result="${options[$index]}"
      return 0
    fi

    # Si c'est ESC, on lit la suite (flèches = ESC [ A/B)
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 key  # lit les 2 caractères suivants, typiquement "[A" ou "[B"
      case "$key" in
        "[A") # flèche haut
          (( index > 0 )) && (( index-- ))
          ;;
        "[B") # flèche bas
          (( index < ${#options[@]} - 1 )) && (( index++ ))
          ;;
      esac
    fi
  done
}
# -------- LINKER --------
link_with_backup() {
  local src="$1"
  local dest="$2"
  local do_backup="$3"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [[ "$do_backup" == "Oui" ]]; then
      local backup="${dest}_bak"
      if [ -e "$backup" ] || [ -L "$backup" ]; then
        backup="${backup}_$(date +%Y%m%d-%H%M%S)"
      fi
      echo "Backup: $dest -> $backup"
      mv "$dest" "$backup"
    else
      echo "Suppression de l'ancien fichier : $dest"
      rm -rf "$dest"
    fi
  fi

  ln -s "$src" "$dest"
  echo "Symlink créé : $dest → $src"
}

# -------- EXECUTION --------
options=("Oui" "Non")
backup_choice=""

choose_with_arrows backup_choice "${options[@]}"

echo
echo "→ Choix backup : $backup_choice"
echo

echo "[1/2] Installation .zshrc"
link_with_backup "$ZSHRC_SRC" "$ZSHRC_DEST" "$backup_choice"

echo "[2/2] Installation dossier zsh"
mkdir -p "$HOME/.config"
link_with_backup "$ZSH_DIR_SRC" "$ZSH_DIR_DEST" "$backup_choice"

echo "✅ Zsh setup finished. Don't forget to 'source ~/.zshrc' !"
echo ""
echo "Thank's using Fluid :)"

#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prevent doublesourcing
if [[ -z "${BASHRCSOURCED}" ]] ; then
  BASHRCSOURCED="Y"
  # the check is bash's default value
  [[ "$PS1" = '\s-\v\$ ' ]] && PS1='[\u@\h \W]\$ '
  case ${TERM} in
    Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*)
      PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
      ;;
    screen*)
      PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
      ;;
  esac
fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

#echo 'export PS1="\[\e[1;35m\]Avalon \u@\h:\w$\[\e[0m\] "' >> /etc/bash.bashrc

# Avalon Prompt
#PS1='\[\e[38;5;201m\]\u\[\e[0m\]@\[\e[38;5;93m\]\h\[\e[0m\]:\[\e[38;5;111m\]\w\[\e[0m\]\$ '
#PS1="\[\e[36;1m\]\u@\h \[\e[33;1m\]\w \[\e[32;1m\]\$ \[\e[0m\]"

PS1="\[\e[36;1m\]\u@\h \[\e[33;1m\]\w \[\e[32;1m\]\$ \[\e[0m\]"
# Usuário@Host Diretório $  (cores Avalon)
#

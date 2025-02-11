alias cdgit='cd ~/git'
alias cdwingit='cd ~/wingit'
alias cdsource='cd ~/source'
alias cdwinsource='cd ~/winsource'
alias cdrjs='cd ~/rjs'
alias cdone='cd ~/one'
alias cdkube='cd ~/one/Documents/kubeconfig'

alias k='kubectl'
alias h='helm'
alias p='kubectl get pods'
alias w='watch kubectl get pods'
complete -F __start_kubectl k
complete -F __start_helm h
source <(kubectl completion bash)
source <(helm completion bash)

export PATH="$HOME/.local/bin:$PATH"

# nc-devbox 
export CLEANUP_FREQUENCY=Monthly
export AZURE_VM_SHUTDOWN_TIME="1300"
export AZURE_LOCATION="uswest2"
export DEBUG=1
export AZURE_RESOURCE_GROUP_NAME="robstarling-devbox-rg-2502"

rr() {
        echo grep -i -r "$1" --include="*$2" ./
        grep -i -r "$1" --include="*$2" ./
}


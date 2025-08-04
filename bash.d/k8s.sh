# This workaround does not always work, I tried to run after/before/during k9s,
# and I don't always see "Shell" button.
#
#    find ~/.xdg-XXX/k9s/clusters/ -name config.yaml | xargs -t -n1 yq -i '.k9s.featureGates.nodeShell = true'
#
# Refs: https://github.com/derailed/k9s/issues/1001
export K9S_FEATURE_GATE_NODE_SHELL=true

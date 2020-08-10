#!/bin/bash 

project=$(git rev-parse --show-toplevel)
cat > ${project}/.git/hooks/post-checkout <<EOF
#!/bin/bash
source profile.env
EOF

chmod +x ${project}/.git/hooks/post-checkout

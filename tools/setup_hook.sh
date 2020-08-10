cat > ../.git/hooks/post-checkout <<EOF
#!/bin/bash
source profile.env
EOF

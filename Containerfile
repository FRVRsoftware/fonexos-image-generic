# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Base Image
FROM quay.io/fedora/fedora-silverblue:44   

# Modifications for FonexOS.
# Generic, last modified: Aug, 

# 1. Ghostty
# Idea/Author: Kevin D.
RUN dnf -y remove ptyxis
RUN dnf copr enable scottames/ghostty 
RUN dnf -y install ghostty 

# 2. Cachy Kernel
# Idea/Author: Kevin D.
RUN sudo dnf copr enable bieszczaders/kernel-cachyos 
RUN sudo dnf -y install kernel-cachyos-lts kernel-cachyos-lts-devel-matched libdnf5-plugin-actions
RUN sudo setsebool -P domain_kernel_load_modules on

# 3. Enable aterisks when typing password (sudo)
# Idea/Author: Kevin D.
RUN echo "Defaults pwfeedback" >> /etc/sudoers

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

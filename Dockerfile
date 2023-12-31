FROM nvidia/cuda:12.0.0-runtime-ubuntu20.04

LABEL maintainer "David 'Inglebard' RICQ <davidricq87@orange.fr>"

RUN apt-get update && apt-get install -y \
	ca-certificates \
	curl \
	python3 \
	unzip \
	libgl1 \
	libglib2.0-0 \
	bzip2 \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*


ENV HOME /home/user

RUN useradd --create-home --home-dir $HOME user \
	&& chown -R user:user $HOME \
	&& mkdir /opt/easy-diffusion/ \
	&& chown -R user:user /opt/easy-diffusion/

WORKDIR $HOME
USER user

ENV LANG C.UTF-8

#https://github.com/easydiffusion/easydiffusion/releases
ENV STABLE_DIFFUSION_UI_VERSION v2.5.24

RUN cd /tmp \
	&& curl -sSOL "https://github.com/easydiffusion/easydiffusion/releases/download/${STABLE_DIFFUSION_UI_VERSION}/Easy-Diffusion-Linux.zip" \
	&& unzip /tmp/Easy-Diffusion-Linux.zip -d /opt \
	&& rm /tmp/Easy-Diffusion-Linux.zip \
	&& cd /opt/easy-diffusion/ \
	&& sed -i 's/exec .\/scripts\/on_sd_start.sh/#exec .\/scripts\/on_sd_start.sh/g' /opt/easy-diffusion/scripts/on_env_start.sh \
	&& bash start.sh \
	&& sed -i 's/#exec .\/scripts\/on_sd_start.sh/exec .\/scripts\/on_sd_start.sh/g' /opt/easy-diffusion/scripts/on_env_start.sh \
	&& cp /opt/easy-diffusion/scripts/on_sd_start.sh /opt/easy-diffusion/scripts/on_sd_start.sh.ori \
	&& cp /opt/easy-diffusion/scripts/on_env_start.sh /opt/easy-diffusion/scripts/on_env_start.sh.ori \
	&& head -n -5 /opt/easy-diffusion/scripts/on_sd_start.sh.ori > /opt/easy-diffusion/scripts/on_sd_start.sh \
	&& sed -i '11,43d' /opt/easy-diffusion/scripts/on_env_start.sh \
	&& bash start.sh \
	&& mv /opt/easy-diffusion/scripts/on_sd_start.sh.ori /opt/easy-diffusion/scripts/on_sd_start.sh \
	&& mv /opt/easy-diffusion/scripts/on_env_start.sh.ori /opt/easy-diffusion/scripts/on_env_start.sh \
	&& echo '{"render_devices": "auto", "update_branch": "main", "ui": {"open_browser_on_start": false}, "net": {"listen_port": 9000,"listen_to_network": true}}' > /opt/easy-diffusion/scripts/config.json \
	&& rm -r /home/user/.conda


EXPOSE 9000

CMD /opt/easy-diffusion/start.sh

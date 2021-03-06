FROM centos:6.8
MAINTAINER Anton Benkevich

ENV sys_user anton
ENV sys_user_password passw0rd
ENV git_user Anton Benkevich
ENV git_email anton.benkevich@gmail.com

## Dnsmasq configure first
RUN yum install dnsmasq -y
COPY files/dnsmasq.d/* /etc/dnsmasq.d/
RUN echo "conf-dir=/etc/dnsmasq.d" > /etc/dnsmasq.conf
RUN /etc/init.d/dnsmasq start

## Add additional software repos
RUN yum install -y epel-release
RUN yum install -y centos-release-SCL

## Install system tools and utils
RUN yum install openssh-server openssh-client -y
#RUN yum install NetworkManager-openconnect -y
RUN yum install bash-completion sudo wget vim tmux rsyslog dnsmasq -y

## Install dev tools
RUN yum install gcc automake autoconf git -y

##setup erlang repo
ADD http://packages.erlang-solutions.com/rpm/centos/erlang_solutions.repo /etc/yum.repos.d/

## setup erlang
#RUN yum install esl-erlang-18.3-1 -y
#RUN yum install esl-erlang-17.5.3 -y
RUN yum install esl-erlang-R16B03-6 -y

## alternative ways to install erlang
#RUN yum install http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_16.b.3-1~centos~6_amd64.rpm -y
#RUN yum install http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_17.5-1~centos~6_amd64.rpm -y
#RUN yum install http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_18.3-1~centos~6_amd64.rpm -y
#RUN wget https://raw.githubusercontent.com/kerl/kerl/master/kerl -O /root/kerl

##Configure steps

## Dev User setup
RUN groupadd sudo
RUN useradd ${sys_user} -g sudo
RUN echo ${sys_user}:${sys_user_password} | chpasswd
RUN echo '%sudo    ALL=(ALL)       ALL' >> /etc/sudoers
RUN echo "git config --global user.name \"${git_user}\"" >> /home/${sys_user}/.bash_profile
RUN echo "git config --global user.email ${git_email}" >> /home/${sys_user}/.bash_profile
RUN echo "git config --global core.editor vim" >> /home/${sys_user}/.bash_profile

## Install ssh identity
COPY files/dot_ssh/* /home/${sys_user}/.ssh/
RUN chown -R ${sys_user} /home/${sys_user}/.ssh/

## Install monitoring
RUN yum install monit -y
COPY files/monit.d/* /etc/monit.d/
COPY files/monit.conf /etc/monit.conf
RUN chmod -R 700 /etc/monit.*

## Run
RUN /etc/init.d/sshd start
CMD ["/usr/bin/monit", "-I"]
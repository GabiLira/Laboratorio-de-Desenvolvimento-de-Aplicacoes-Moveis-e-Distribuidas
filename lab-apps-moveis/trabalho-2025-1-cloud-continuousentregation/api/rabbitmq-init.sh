#!/bin/bash
# filepath: ./rabbitmq-init.sh

# Espera o RabbitMQ subir
sleep 10

# Cria usuário, define como admin e dá permissões
rabbitmqctl add_user continuousentregation ceapp
rabbitmqctl set_user_tags continuousentregation administrator
rabbitmqctl set_permissions -p / continuousentregation ".*" ".*" ".*"
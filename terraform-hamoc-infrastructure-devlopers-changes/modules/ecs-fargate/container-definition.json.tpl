[
  {
    "image": "${image}",
    "name": "${name}",
    "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-region" : "${region}",
                    "awslogs-group" : "${loggroup}",
                    "awslogs-stream-prefix" : "${stream}"
                }
            },
    "secrets": ${secrets},           
    "environment": ${environment},
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${containerport}
      }
    ]
    }
]
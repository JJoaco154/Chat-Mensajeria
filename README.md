
# 💬 Chat Multicliente con Node.js, PostgreSQL y Docker

Proyecto personal de un **chat multicliente** desarrollado con Node.js, PostgreSQL y Docker.

La idea del proyecto es crear un servidor capaz de aceptar múltiples clientes al mismo tiempo, permitiendo que estos se comuniquen mediante mensajes y almacenando el historial en una base de datos PostgreSQL.

Este proyecto fue realizado **por iniciativa propia** con el objetivo de aprender más sobre servidores, comunicación entre clientes, bases de datos y contenedores.

---

## 📌 Sobre el proyecto

El sistema está compuesto principalmente por:

- Un servidor multicliente.
- Clientes que se conectan al servidor.
- Una base de datos PostgreSQL.
- Contenedores Docker para separar los diferentes componentes.

Los clientes se conectan al servidor mediante una conexión TCP y pueden enviar mensajes.

El servidor recibe los mensajes y los distribuye entre los clientes conectados.

Además, los mensajes pueden almacenarse en PostgreSQL para mantener un registro de las conversaciones.

---

## 🏗️ Arquitectura

El proyecto está dividido en diferentes componentes:

```text
┌──────────────┐
│   Cliente 1  │
└──────┬───────┘
       │
       │ TCP
       │
┌──────▼───────┐
│    Servidor  │
│   Node.js    │
└──────┬───────┘
       │
       │ PostgreSQL
       │
┌──────▼───────┐
│  Base de     │
│   Datos      │
│ PostgreSQL   │
└──────────────┘

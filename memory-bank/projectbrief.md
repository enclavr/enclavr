# Project Brief - Enclavr

## Project Overview
Enclavr is a self-hosted open source voice chat platform written in Go with a Next.js default frontend.

## Core Requirements
1. **Backend**: Go-based API server
2. **Frontend**: Next.js (default), frontend-agnostic design
3. **Authentication**: Built-in auth with optional OIDC support
4. **Database**: Strong database for heavy workload
5. **Architecture**: Single server with multiple rooms
6. **Deployment**: Containerized support
7. **Real-time**: Voice communication capabilities

## Goals
- Create a performant, self-hosted voice chat solution
- Provide a complete backend that any frontend can consume
- Enable easy deployment via Docker/containerization
- Support enterprise features like OIDC authentication

## Deliverables
- Go backend server with REST/gRPC APIs
- WebSocket support for real-time voice
- PostgreSQL database integration
- Next.js frontend reference implementation
- Docker Compose for easy deployment

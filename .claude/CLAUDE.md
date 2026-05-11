# PeptidesTrack — Claude Code Instructions

## LEIA ISTO ANTES DE QUALQUER CÓDIGO

Este é o arquivo de instruções automáticas do Claude Code para o projeto PeptidesTrack.
Toda sessão começa aqui. Não pule. Não ignore.

---

## PASSO 1 — Leia os arquivos de referência obrigatórios

Antes de escrever, modificar ou deletar qualquer linha de código, leia:

1. `PEPTIDESTRACK_RULES.md` — regras invioláveis de localization, design, qualidade e App Store compliance
2. `PEPTIDESTRACK_MVP_MASTER.md` — spec completo do produto: todas as telas, modelos, strings, arquitetura

---

## PASSO 2 — Contexto do projeto

```
App:            PeptidesTrack
Bundle ID:      com.peptidestrack.app
Plataforma:     iOS 17.0+ · Swift 6.0 · SwiftUI · SwiftData · StoreKit 2
Repositório:    github.com/RobExtremeVoice/pptdtrck_app
Developer:      Robson (@RobExtremeVoice)
Design:         Dark-first · Primary #06B6D4 · Accent #8B5CF6 · BG #080C18
Modelo negócio: 1 mês grátis → PRO $4.99/mês (StoreKit 2 introductory offer)
```

---

## PASSO 3 — Regras que nunca podem ser quebradas

### Localization (REGRA ZERO)
- ZERO strings hardcoded em qualquer idioma no código Swift
- Cada string nova = entry obrigatória em TODOS os 4 idiomas

### Design System
- Cores: APENAS via `Color(hex: "XXXXXX")` da paleta oficial
- NUNCA: `Color.blue`, `Color.white`, `Color.black`

### SF Symbols
- APENAS `Image(systemName:)` — zero image assets para ícones funcionais
```

---

## PASSO 4 — Estrutura de arquivos

```
PeptidesTrack/
├── App/
├── Models/
├── Store/
├── Notifications/
├── Views/
├── Components/
├── Extensions/
└── Resources/
    └── Localizations/
        ├── en.lproj/
        ├── pt-BR.lproj/
        ├── es.lproj/
        └── de.lproj/
```

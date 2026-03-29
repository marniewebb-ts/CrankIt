![Crank It App Icon](./CI_AppIcon.png)

# Crank It 

**Crank It** is an iOS utility designed to support a streamlined sharing workflow. It makes it simple to capture a quote, its source, and your own comments from a webpage or RSS reader and publish it directly to your Micro.blog account.

### Motivation
I built Crank It because I wanted something that matched my personal workflow. None of the existing tools quite worked for me. This project also gave me a specific goal to learn a lot about Vibe Coding, how to navigate complex developer environments, and how to manage a project on GitHub. 

My goal was to solve a personal workflow need while approaching the build with a combined product manager mindset and a learning perspective.

### What it Does
* **Streamlined Sharing:** Captures webpage details and posts them in one action.
* **Format-driven Constraint:** Enforces a strict **280-character limit** to encourage concise, focused posts.
* **Minimalist UI:** A clean, uncluttered SwiftUI interface.
* **Micropub Integration:** Posts directly to Micro.blog using the Micropub protocol.

### Technical Details
The app consists of a main SwiftUI application and a system-level Share Extension. For a deep dive into the architecture, App Group configuration, and how to customize this for your own account, see [TECHNICAL_DOCS.md](./TECHNICAL_DOCS.md).

### The Process
The journey of building Crank It was documented as it happened. For an honest account of the build, the toolset choices, and where the collaboration with Gemini stumbled, see [PROCESS.md](./PROCESS.md).

# Dynamixs.AI – Partner Integration Guide

Dynamixs.AI is an Agentic Enterprise AI Plattform for modern Business Process Management. It follows a **Low-Code approach** to model Business processes with BPMN 2.0 including process flows, AI integration, Agents, AI conditions and business rules. Business processes are defined visually using [Open-BPMN](https://www.open-bpmn.org/) — a free BPMN 2.0 modeler that runs in VS Code, Eclipse, or directly in the browser.


[![Open-BPMN Modeler](https://camo.githubusercontent.com/bab1d0e514e639c59ef8c1b60ae1a071b2840cbbf03bd26cb4b62130cb480667/68747470733a2f2f7777772e6f70656e2d62706d6e2e6f72672f696d616765732f696d6978732d62706d6e2d3030312e706e67)](https://www.open-bpmn.org/)

- 📦 [Install Open-BPMN](https://www.open-bpmn.org/install.html)
- 🎓 [How to Model](https://www.open-bpmn.org/how_to_model.html)
- 🔷 [BPMN Model Library](https://github.com/dynamixs-ai/bpmn-library)

---


## Two Ways to Use This Template

This template is the starting point for **every** Dynamixs.AI partner project — but it can be used in two very different ways, depending on your needs:

- **🚀 Run it as-is (Docker only).** Use the pre-built Dynamixs.AI Docker image and only work inside the `/bpmn` folder to model your business processes visually. No Java or Maven knowledge required. This is comparable to running WordPress: you don't modify the core application, you configure and extend it through content (here: BPMN models).
- **🛠️ Customize it (Java/Maven).** Build your own WAR overlay on top of the platform to add custom UI components, branding, or backend logic in Java. This requires familiarity with Maven and Java, and is meant for partners with deeper integration needs.

Not sure which one you need? Start with the Docker option -  you can always move to the Maven-based customization later without losing your BPMN models.


## Choosing Your Deployment Option

|                | **Option A – Docker Compose** | **Option B – Maven Build (WAR Overlay)** |
| -------------- | ------------------------------ | ------------------------------------------ |
| Effort         | Low                             | Higher                                     |
| Skills needed  | Docker only                     | Java 17+, Maven 3.9+                       |
| Customizable   | BPMN models only                | UI, CDI beans, Java services, branding     |
| Best for       | Evaluation, standard deployments, external ERP integration via REST | Deep UI customization, long-lived partner products |
| Get started →  | [Jump to Option A](#option-a-quick-start-with-docker-compose) | [Jump to Option B](#option-b-custom-build-war-overlay) |

Both options run on the same Docker infrastructure underneath - the difference is only whether you use the pre-built image or build your own WAR first.


## Getting Started: Create Your Own Repository

Regardless of which option you choose, you start the same way: create your **own, independent repository** from this template — don't fork it and don't clone it directly.

1. Go to the [dynamixs-partner-template](https://github.com/dynamixs-ai/dynamixs-partner-template) repository on GitHub.
2. Click the green **"Use this template"** button (top right, next to "Code") and select **"Create a new repository"**.
3. Choose a name for your project (e.g. `acme-workflow`) and select your own account or organization as the owner.
4. Clone *your new repository* to your machine:

```bash
   git clone https://github.com/YOUR_ACCOUNT/acme-workflow.git
   cd acme-workflow
```

> **Why not fork or clone the template directly?** A fork stays linked to the original Dynamixs.AI repository and shares its commit history — that's meant for contributing back to the template itself, not for building your own project on top of it. "Use this template" gives you a clean, independent repository with your own history, owned by you, containing all the files (`/bpmn`, `/docker`, `/src`) you need for both Option A and Option B.

From here, both options continue inside *your* repository:

- **Option A** — you'll mainly work in `/bpmn` and `/docker`.
- **Option B** — you'll additionally work in `/src` and `pom.xml`.

--- 


## Prerequisites

The Dynamixs.AI – Partner Template contains artifacts and examples that help you to get started with your custom project.

This repository is organized as follows:

- `/bpmn` – BPMN model examples and basic templates
- `/docker` – Docker Compose templates
- `/src` – scaffold for a custom web application (only relevant for Option B)

Before you start make sure you have: 

- Docker & Docker Compose
- A Dynamixs.AI Partner Account on GitHub (required for Option B)
- An LLM endpoint compatible with the OpenAI API (for AI features)

> **Becoming a Partner**
> Contact us at partner@dynamixs.ai to get access to the Dynamixs.AI GitHub packages and partner resources.

---

## Option A: Quick Start with Docker Compose

### 1. Get the Docker Compose file

Use the official `docker-compose.yml` provided by Dynamixs.AI. It includes all required
services out of the box:

| Service              | Description                   |
| -------------------- | ----------------------------- |
| Wildfly 32           | Jakarta EE Application Server |
| PostgreSQL           | Primary database              |
| Cassandra            | Archive / document store      |
| Apache Tika          | OCR service                   |
| Collabora Online     | Document editing (WOPI)       |
| Prometheus + Grafana | Monitoring                    |

### 2. Configure the LLM endpoint

Dynamixs.AI uses an LLM endpoint registry file (`imixs-llm.xml`) to connect to AI services.
Create this file and place it somewhere accessible to the container (e.g. `./keys/imixs-llm.xml`).

**Example `imixs-llm.xml`:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<imixs-llm>

    <!--
        Completion endpoint - used for chat completions, conditions, and analysis.
        Connects to a local llama.cpp server or any OpenAI-compatible API.
    -->
    <endpoint id="my-llm">
        <url>http://localhost:8080/</url>
        <apikey>${env.LLM_API_KEY}</apikey>
        <options>
            <temperature>0.2</temperature>
            <max_tokens>1024</max_tokens>
        </options>
    </endpoint>

    <!--
        Embedding endpoint - used for RAG indexing and retrieval.
        Can be hosted separately; no API key needed for local instances.
    -->
    <endpoint id="my-embeddings">
        <url>http://localhost:8081/</url>
        <options>
            <max_tokens>512</max_tokens>
        </options>
    </endpoint>

</imixs-llm>
```

Endpoints are referenced by their `id` in the BPMN process configuration:

```xml
<!-- Simple completion task -->
<imixs-ai name="CONDITION">
    <endpoint>my-llm</endpoint>
</imixs-ai>

<!-- RAG task with separate embeddings endpoint -->
<imixs-ai name="RAG_INDEX">
    <endpoint-completion>my-llm</endpoint-completion>
    <endpoint-embeddings>my-embeddings</endpoint-embeddings>
</imixs-ai>
```

Environment variable placeholders like `${env.LLM_API_KEY}` are resolved at runtime.
You can define them in `./docker/.env`:

```
LLM_API_ENDPOINT=https://my.llama.cpp.foo.com/
LLM_API_KEY=your-api-key-here
```

### 3. Docker Image

All ai-platform Docker images are available via GitHub Container Registry (GHCR).
To Pull the Docker Image, first, authenticate with GHCR using your PAT:

**Step 1 – Create a Personal Access Token**

- Go to GitHub → Profile Settings → Developer settings → Personal access tokens → Tokens (classic)
- Click "Generate new token (classic)"
- Set a meaningful note, e.g. dynamixs-maven-access
- Select the following scope:
  read:packages
- Click "Generate token" and copy it immediately – you won't see it again

**Step 2a - login with docker**

Log your Docker CLI in to the registry:

    echo YOUR_PERSONAL_ACCESS_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin

**Step 2b - login with kubernetes**

For **Kubernetes Cluster** create a so called Image Pull Secret:

```
$ kubectl create secret docker-registry ghcr-pull-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_PERSONAL_ACCESS_TOKEN \
  --docker-email=YOUR-EMAIL \
  -n NAMESPACE
```

And set the secret into your deployment config:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dynamixs-ai
  labels:
    app: dynamixs-ai
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dynamixs-ai
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: dynamixs-ai
    spec:
      imagePullSecrets:
        - name: ghcr-pull-secret
      containers:
        - name: dynamixs-ai
          image: ghcr.io/dynamixs-ai/ai-platform:1.0.1-SNAPSHOT
......
```

### 4. Start the stack

```bash
docker compose up -d
```

The application will be available at `http://localhost:8080`.

---

## Setup your Application

After the stack is up and running, open your browser at `http://localhost:8080` and log in
with the default admin account (`admin` / `adminadmin`).

You need to complete four steps to get your first workflow running:

### 1. Upload a BPMN Workflow Model

Go to **Administration → Models** and upload a BPMN file. Ready-to-use templates are
available in our [BPMN library](https://github.com/dynamixs-ai/bpmn-library).

![Upload a BPMN model](docs/images/setup-01.png)

### 2. Create a Process

Go to **Administration → Processes** and create a new process.

![Create a new process](docs/images/setup-02.png)

### 3. Assign the Workflow Model

Assign the uploaded BPMN model to your new process.

![Assign the workflow model](docs/images/setup-03.png)

### 4. Start the Workflow

The new process now appears on the home screen. Click on it to start the corresponding workflow.

![Start the workflow](docs/images/setup-04.png)

---

## Option B: Custom Build (WAR Overlay)

This option is based on the Maven WAR Overlay mechanism. The Dynamixs.AI platform UI
(`dynamixs-platform-ui`) is used as the base WAR. Your files in `src/main/webapp/`
automatically take precedence over files from the base WAR.

The build chain looks like this:

```
imixs-office-workflow-app   (WAR, public on Sonatype)
        ↓ overlay
dynamixs-platform-ui        (WAR, Dynamixs.AI GitHub Packages)
        ↓ overlay
acme-workflow               (WAR, your custom build)
```

Each layer only overrides what it needs — everything else is inherited from below.

### Prerequisites

- Java 17+
- Maven 3.9+
- A Dynamixs.AI Partner Account on GitHub

### 1. Configure Maven credentials

Add the following to your local `~/.m2/settings.xml`:

```xml
<settings>
    <servers>
        <server>
            <id>github-dynamixs</id>
            <username>YOUR_GITHUB_USERNAME</username>
            <!-- Personal Access Token with read:packages permission -->
            <password>YOUR_GITHUB_TOKEN</password>
        </server>
    </servers>
</settings>
```

Create a GitHub Personal Access Token with `read:packages` permission here:
https://github.com/settings/tokens

### 2. Clone the partner template

```bash
git clone https://github.com/dynamixs-ai/dynamixs-partner-template.git acme-workflow
cd acme-workflow
```

### 3. Customize `pom.xml`

Change `groupId`, `artifactId`, and `finalName` to match your customer project:

```xml
<groupId>com.acme</groupId>
<artifactId>acme-workflow</artifactId>
...
<finalName>acme-workflow</finalName>
```

### 4. Build

```bash
mvn clean package
```

The custom WAR file will appear in `target/`.

---

## Customizing the UI (Option B)

To override a file (CSS, XHTML, JSF component) simply copy it into `src/main/webapp/`.
Maven will automatically prefer your version over the base.

To inspect all available files you can override, unpack the base WAR:

```bash
mvn dependency:unpack -Dartifact=ai.dynamixs:dynamixs-platform-ui:LATEST:war -DoutputDirectory=target/platform-ui
```

Browse `target/platform-ui/` and copy any file you want to customize into `src/main/webapp/`.

**Example: override the default stylesheet**

```
src/main/webapp/resources/css/custom.css
```

---

## Adding Customer-specific Code (Option B)

Add your own CDI beans and services under `src/main/java/`. For example a connector
to an ERP system:

```
src/main/java/
└── com/acme/
    └── erp/
        └── SAPConnector.java
```

This code is owned by your customer — not by Dynamixs.AI.

Add the corresponding dependency in your `pom.xml` if needed:

```xml
<dependency>
    <groupId>com.acme</groupId>
    <artifactId>sap-connector</artifactId>
    <version>1.0.0</version>
</dependency>
```

---

## Project Structure (Option B)

```
your-project/
├── pom.xml                        ← extend this
├── docker/                        ← Docker Compose setup (provided by Dynamixs.AI)
└── src/main/
    ├── java/
    │   └── com/acme/              ← your custom CDI beans and services
    └── webapp/
        ├── WEB-INF/
        │   └── web.xml            ← optional: add your own servlets/filters
        ├── layout/
        │   ├── css/
        │   │   └── custom.css     ← override platform styles
        │   └── components/        ← add custom JSF components here
        └── pages/
            └── workitems/
                └── parts/         ← override form parts
```

---

## Upgrading the Platform Version

To upgrade to a new version of Dynamixs.AI, change the version property in your `pom.xml`:

```xml
<ai.dynamixs.version>1.1.0</ai.dynamixs.version>
```

Then rebuild with `mvn clean package`. Your customizations in `src/main/webapp/`
are never touched by the upgrade.

---

## BPMN Process Models

Ready-to-use BPMN process templates are available in our public library:
https://github.com/dynamixs-ai/bpmn-library

---

## Resources

| Resource               | URL                                    |
| ---------------------- | -------------------------------------- |
| Dynamixs.AI Website    | https://www.dynamixs.ai                |
| Platform Documentation | https://doc.dynamixs.ai                |
| Imixs-Workflow         | https://www.imixs.org                  |
| Imixs-Office-Workflow  | https://doc.office-workflow.com        |
| Custom Build Guide     | https://doc.office-workflow.com/build/ |
| Partner Support        | support@dynamixs.ai                    |
| Partner Onboarding     | partner@dynamixs.ai                    |

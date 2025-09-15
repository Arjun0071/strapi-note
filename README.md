Strapi Notes Project

A simple Strapi project to manage Note content type, built locally using Strapi v5.23.4 on WSL Ubuntu.

Table of Contents

Prerequisites

Task 1 — Strapi Setup on WSL Ubuntu (DevOps Checklist)

Project Setup

Run Locally

Content Types

Sample Content

Accessing Data via API

GitHub Repository

Optional: Loom Video

Prerequisites

WSL Ubuntu (or Linux environment)

Node.js LTS v18.x

Yarn (v1.x)

Git

Browser to access Strapi Admin Panel

✅ Task 1 — Strapi Setup on WSL Ubuntu (DevOps Checklist)
Step 0 — WSL Ubuntu Prerequisites
sudo apt update && sudo apt upgrade -y          # Update system packages
sudo apt install curl -y                        # Install curl
sudo apt install git -y                         # Install Git
git --version                                   # Verify Git installation


Install Node.js (LTS 18.x recommended):

curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node -v      # Verify Node version
npm -v       # Verify npm version


Install Yarn:

sudo npm install --global yarn
yarn -v     # Verify Yarn installation


Optional check:

node -e 'console.log("Node is working on WSL!")'

Step 1 — Clone Strapi Repository
cd ~/projects || mkdir -p ~/projects && cd ~/projects
git clone https://github.com/strapi/strapi.git
cd strapi

Step 2 — Install Dependencies
yarn install


✅ This will create node_modules and prepare Strapi for local development.

Step 3 — Creating a New Project
cd ~/newprojects
yarn create strapi my-strapi-project


✅ This creates a new folder my-strapi-project for your runnable Strapi project.
Yarn will scaffold your project with:

package.json → project dependencies & scripts

node_modules/ → installed packages

src/ → backend code (API, plugins, config)

.git/ → if you chose to initialize Git

README.md and other config files

What happens when you run it:

Yarn fetches the create-strapi package.

CLI prompts guide you through: database choice, TypeScript, example data, dependencies, git init.

After finishing, you get a fully scaffolded Strapi project, ready to run locally.

Step 4 — Run the Project
cd ~/newprojects/my-strapi-project
yarn run develop


Admin Panel: http://localhost:1337/admin

First-time setup: create an admin account (email + password)

After logging in, you can:

Explore the project folder structure

Start the Admin Panel

Create a sample content type

Content Types
Note

Fields created:

title (Text, short)

body (Long text)

publishedOn (Date)

Sample Content
Title	Body	Published On
Meeting Notes	Discussed project milestones and tasks	2025-09-15
Grocery List	Eggs, milk, bread, peanut butter, coffee	2025-09-14
Accessing Data via API

Enable public permissions in Settings → Roles → Public for find and findOne.

Use these endpoints:

All notes: http://localhost:1337/api/notes

Single note: http://localhost:1337/api/notes/1

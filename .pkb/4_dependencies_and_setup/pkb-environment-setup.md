# Protevus Platform Environment Setup

This guide will walk you through the steps required to set up your development environment for the Protevus Platform. It covers the installation of required dependencies, configuration of environment variables, and other necessary setup tasks.

## Prerequisites

Before you begin, ensure that you have the following prerequisites installed on your system:

- **Dart SDK** (version X.X.X or later)
- **Git** (for cloning the Protevus Platform repository)

## Step 1: Clone the Protevus Platform Repository

Open your terminal or command prompt and navigate to the directory where you want to clone the Protevus Platform repository. Then, run the following command:

~~~bash
git clone https://github.com/protevus/platform.git
~~~

This will create a local copy of the Protevus Platform codebase on your machine.

## Step 2: Install Dependencies

Next, navigate into the cloned repository directory:

~~~bash
cd platform
~~~

Install the required dependencies by running the following command:

~~~bash
dart pub get
~~~

This command will download and install all the necessary packages and dependencies listed in the `pubspec.yaml` file.

## Step 3: Configure Environment Variables

The Protevus Platform requires certain environment variables to be set for proper configuration and operation. Create a new file named `.env` in the root directory of the cloned repository and add the following variables:

~~~bash
APP_ENV=development APP_KEY=your_app_key_here DB_CONNECTION=sqlite DB_DATABASE=database/database.sqlite
~~~

Replace `your_app_key_here` with a secure, random string that will be used for encryption and hashing purposes.

## Step 4: Set up the Database (Optional)

If you plan to use the database functionality of the Protevus Platform, you'll need to set up a database. The default configuration uses SQLite, but you can also configure other database systems like MySQL or PostgreSQL.

For SQLite, create a new directory named `database` in the root of the cloned repository, and create an empty file named `database.sqlite` within it.

## Step 5: Run the Development Server

With the environment set up and dependencies installed, you can now run the development server. In the terminal or command prompt, navigate to the root directory of the cloned repository and run the following command:

~~~bash
dart bin/server.dart
~~~

This will start the Protevus Platform development server, and you should see output indicating that the server is running and listening on a specific port (e.g., `http://localhost:8080`).

## Step 6: Verify the Installation

To verify that the installation was successful, open a web browser and navigate to the URL displayed in the terminal or command prompt (e.g., `http://localhost:8080`). You should see a welcome message or the default homepage of the Protevus Platform.

Congratulations! You have successfully set up your development environment for the Protevus Platform. You can now start building your applications or contributing to the project.




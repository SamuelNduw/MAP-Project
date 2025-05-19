# Namibia Hockey Union App

A mobile application project. This application allows for teams and members to view league, team and player details. With admin CRUD operations that allow the application to have content.

# Technologies/Languages

- Flutter
- Django Rest Framework
- MySQL

# Usage Instructions

#### To run the application you need to follow all the steps under `Database`, `Frontend` and `Backend`.
#### Once complete, login with the superuser/admin credentials, then populate the application with data using the various creation pages.

## Database
Create a database using the following script (preferrably in MySQL Workbench): \
`CREATE DATABASE hockeyunion`

## Backend

###  Create a Virtual Environment
#### Navigate to the `Backend` directory.
```
cd Backend

python -m venv virt
``` 
#### Activate it:
#### Windows
`.\virt\Scripts\activate`
#### Mac/Linux
`source virt/bin/activate`

### Install packages and libraries
`pip install -r requirements.txt`
#### or
`pip3 install -r requirents.txt`

### Environment Variables
- Create a file called `.env`
- Copy everything from `.env.example`
- Paste the copied elements in the `.env` file
- Change the values in the `.env` file to your configurations

### Make Migrations
#### Navigate to `Backend/hockeyapp/` then execute the commands
```
cd hockeyapp
python manage.py makemigrations
python manage.py migrate
```

### Create Superuser/Admin
`python manage.py createsuperuser`

### Run the server (from the root Backend directory)
`python manage.py runserver`

## Frontend
### Running the App on Android Emulator (via Android Studio Emulator + VS Code)

Ensure you have:
- **Flutter SDK (≥ 3.29.3)**
- **Dart SDK (3.7.2, included with Flutter)**
- **Android Studio (for emulator management)**
- **VS Code with Flutter & Dart extensions**

---
#### 1. Start your Android emulator from Android Studio: 
- Open Android Studio → Device Manager
- Start your preferred virtual device (AVD)

#### 2. Verify the emulator is recognized by Flutter:

`flutter devices` \
You should see your emulator listed.

#### 3. Run the app from VS Code:
- Open the project folder in VS Code
- Make sure your emulator is running
- Run the following in the terminal:

`flutter run`

- Or use **Run → Start Debugging** (F5)

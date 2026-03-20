# QizMe

## Please take time to read this. This is crucial for the application's structure
The files in this application is stored in the `lib` folder.

In this folder, there are different folders, but do not worry, here is the breakdown of the purpose of each folders (subject to change)

Firstly, the `controllers` folder.
- The controllers folder handles the logic (for example, the login_controller handles the login logic for the login page )
- Let us use the login for example
- Without the controllers, the login would not know when to load the loading screen after clicking login, and also, the login function would not do anything

Second, the `repositories` folder
- This folder is responsible in providing the function `controllers` needed. 
- This folder acts as a "second hand" to the controllers folder
- Without this folder, the controllers folder would not know what to execute 
- For example, the login. Without repository, the controllers folder would not know what to do next after receiving the required data from the user (or front end)

Third, the `services` folder
- This helps create a connection between the endpoint and the application
- This connects with the API

For summary:
- Without `services`, the repository would not know how to interact with the API for authentication.
- Without the `repository`, the controller would not know how what to do with the response data.
- Without the `controller`, nothing will happen.

Fourth, the `utils`
- The utils folder are the functions that is not really bounded to a file (e.g. login), but is used to reduce function declaration redundancy (declaring the same function in other parts of the application)

Fifth, the `views` folder
- This is where all the screens is saved
- You can think of this as the parts of the application
- This is where different parts of the application is divided, making the application readable

Sixth, the `tabs` folder
- We can use the edit account as an example.
- In the figma, when we go to the edit account, everything changes except for the top and bottom bar
- To achieve this, we use tabs. We retain the top and bottom bar, but we only change the main or content part
- Like in HTML, the navigation bar and footer should be in the pages no matter what, the principle applies also here
- This can also be called as shared layout plus tab or page content

Seventh, the `widgets` folder
- This is where the parts of the screens are separated
- For example, for the menu page, it is divided into the parts for the avatar, buttons, and logout
- So that the items inside a screen (e.g. buttons in the menu page) will not be cramped into one place, making it readable

Eight, the `constants.dart`
- This is where the values that do not change is saved
- However, it is not included since it contains the endpoint (This is technically wrong, but for simplicity, I would not install dotenv since it will complicate things more imo)

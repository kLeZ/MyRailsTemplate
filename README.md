MyRailsTemplate
===============
This is a Rails Application Template written to automatise my personal common tasks when creating rails applications.<br/>
You can generate a new app with this template executing the following command:<br/>
`rails new APP_PATH -m MyRailsTemplate/template.rb -d mysql`<br/>
<br/>
LICENSE
-------
MyRailsTemplate  Copyright (C) 2014  Alessandro Accardo<br/>
This program comes with ABSOLUTELY NO WARRANTY.<br/>
This is free software, and you are welcome to redistribute it<br/>
under certain conditions.<br/><br/>

### 1. Components
There are some components which come preconfigured when a rails app is created<br/>
following this template. Below you can find a list of all the components with<br/>
version (ruby and rails included) that will be required and (except the core)<br/>
downloaded in the app setup.<br/>
I've not fixed gems version, so they will be always the latest available.<br/>
For that reason the generated rails app may not work properly.<br/>

### 1.1 Core
- Ruby 2.1.0+
- Rails 4.1.0+
- MySQL 5.5+

### 1.2 Engine
- Devise
- Devise Invitable
- CanCan
- Rolify
- WebSockets

### 1.3 Graphics
- Bootstrap-Sass
- Autoprefixer (recommended by official Bootstrap-Sass team)
- FontAwesome
- Bootswatch
- JQuery
- Formtastic-Bootstrap
- Simple-Form

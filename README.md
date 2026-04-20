# 🚀 Hostal – Social Media Backend API

Hostal is a scalable social media backend built using Django and Django REST Framework (DRF).  
It provides core social features like authentication, posts, likes, comments, and follow systems with a focus on performance, security, and clean architecture.

---

## 🔥 Features

- 🔐 JWT Authentication (Login / Signup)
- 📧 Email Verification System
- 👤 Custom User Model
- 📝 Create / Update / Delete Posts (Image/Video supported)
- ❤️ Like / Unlike Posts
- 💬 Comment System
- 👥 Follow / Unfollow Users
-    hostal complain features
- implement real time chat system (in future)
- ⚡ Background Tasks using Celery (image processing, email sending)
- 🗜️ Image Compression & Optimization
- 🚫 Rate Limiting (Anti-spam protection)

---

## 🏗️ Tech Stack

- **Backend:** Django, Django REST Framework
- **Auth:** JWT (SimpleJWT)
- **Database:** db.sqlite3(dev)  PostgreSQL(prod)
- **Async Tasks:** Celery + Redis
- **Media Handling:** Pillow / Cloud Storage (optional)
- **Deployment Ready:** Gunicorn + Nginx(in future)


## ⚙️ Installation

python -m venv venv
source venv/bin/activate   # Linux
venv\Scripts\activate      # Windows

### 1. Clone Repository

```bash
git clone https://github.com/amanx69/hostal-project/
cd hostal-project
pip install -r req.txt

# than setup .env


Sc= "gernate you sc"
#email

email_b= django.core.mail.backends.smtp.EmailBackend
email_h= smtp.gmail.com
email_port= 587
email_host= "your host email"
email_pass= "your gmail service pass not real pass"


#! than run in bash
python manage.py makemigrations
python manage.py migrate

#in your root project 
python manage.py runserver

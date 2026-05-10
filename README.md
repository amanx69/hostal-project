# 🚀 Hostal — Social Media Backend API

Hostal is a scalable social media backend built with **Django** and **Django REST Framework (DRF)**.  
It provides core social features like authentication, posts, likes, comments, and a follow system — with a focus on performance, security, and clean architecture.

---

## ✨ Features

| Category | Feature |
|---|---|
| 🔐 Auth | JWT Login / Signup |
| 📧 Email | Email Verification System |
| 👤 Users | Custom User Model |
| 📝 Posts | Create / Update / Delete (Image & Video supported) |
| ❤️ Engagement | Like / Unlike Posts |
| 💬 Comments | Comment System |
| 👥 Social | Follow / Unfollow Users |
| 🏠 Hostal | Complaint / Report System |
| ⚡ Tasks | Background Jobs via Celery (image processing, email sending) |
| 🗜️ Media | Image Compression & Optimization |
| 🚫 Security | Rate Limiting (anti-spam protection) |
| 💬 Chat | Real-time Chat *(planned)* |

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| **Backend** | Django, Django REST Framework |
| **Auth** | JWT via `djangorestframework-simplejwt` |
| **Database** | SQLite *(dev)* / PostgreSQL *(prod)* |
| **Async Tasks** | Celery + Redis |
| **Media** | Pillow / Cloud Storage *(optional)* |
| **Deployment** | Gunicorn + Nginx *(planned)* |

---

## ⚙️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/amanx69/hostal-project/
cd hostal-project
```

### 2. Create & Activate a Virtual Environment

```bash
python -m venv venv

# Linux / macOS
source venv/bin/activate

# Windows
venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r req.txt
```

### 4. Configure Environment Variables

Create a `.env` file in the root of the project and add the following:

```env
# Django
SECRET_KEY=your_generated_secret_key_here

# Email
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your_email@gmail.com
EMAIL_HOST_PASSWORD=your_gmail_app_password   # Use an App Password, not your real Gmail password
```

> ⚠️ **Never commit your `.env` file.** Add it to `.gitignore`.

### 5. Run Migrations

```bash
python manage.py makemigrations
python manage.py migrate
```

### 6. Start the Development Server

```bash
python manage.py runserver
```

The API will be available at `http://127.0.0.1:8000/`.



## 🔮 Roadmap

- [x] JWT Authentication
- [x] Email Verification
- [x] Posts (CRUD + Media)
- [x] Likes & Comments
- [x] Follow System
- [x] Hostal Complaint System
- [x] Celery Background Tasks
- [ ] Real-time Chat (WebSockets)
- [ ] PostgreSQL + Production Deployment (Gunicorn + Nginx)
- [ ] Cloud Media Storage (S3 / Cloudinary)





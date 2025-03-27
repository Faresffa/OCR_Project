from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin

db = SQLAlchemy()

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relations
    tickets = db.relationship('Ticket', backref='user', lazy=True)
    cars = db.relationship('Car', backref='owner', lazy=True)

    # Méthodes pour la gestion des mots de passe
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def __repr__(self):
        return f'<User {self.username}>'

class Ticket(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    merchant = db.Column(db.String(200))
    amount = db.Column(db.Float)
    date = db.Column(db.DateTime)
    transaction_id = db.Column(db.String(200))
    image_path = db.Column(db.String(500))
    raw_text = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<Ticket {self.id} - {self.merchant} - {self.amount}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'merchant': self.merchant,
            'amount': self.amount,
            'date': self.date.strftime('%Y-%m-%d %H:%M:%S') if self.date else None,
            'transaction_id': self.transaction_id,
            'raw_text': self.raw_text,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S')
        }

class Car(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    make = db.Column(db.String(50), nullable=False)
    model = db.Column(db.String(50), nullable=False)
    year = db.Column(db.Integer, nullable=False)
    maintenances = db.relationship('CarMaintenance', backref='car', lazy=True)

    def __repr__(self):
        return f'<Car {self.make} {self.model} ({self.year})>'

class CarMaintenance(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    car_id = db.Column(db.Integer, db.ForeignKey('car.id'), nullable=False)
    maintenance_type = db.Column(db.String(100), nullable=False)
    date = db.Column(db.DateTime, nullable=False)
    description = db.Column(db.Text)
    performed_by = db.Column(db.String(100))
    parts_replaced = db.Column(db.Text)

    def __repr__(self):
        return f'<Maintenance {self.maintenance_type} on Car {self.car_id}>'

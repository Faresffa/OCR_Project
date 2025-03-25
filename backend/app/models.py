# # Mod�les SQLAlchemy d�finissant les structures de donn�es dans la base (Tickets, Utilisateurs...)
from datetime import datetime
from .database import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    tickets = db.relationship('Ticket', backref='user', lazy=True)
    
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
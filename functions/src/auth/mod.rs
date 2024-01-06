use actix_web::{web, Scope};

pub fn router() -> Scope {
    web::scope("/auth")
}
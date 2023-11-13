#[macro_use] extern crate rocket;

// Try visiting:
//   http://127.0.0.1:8000/hello/world
#[get("/world")]
fn world() -> &'static str {
    "Hello, world!"
}


#[launch]
fn rocket() -> _ {
    use rocket::fairing::AdHoc;

    rocket::build()
        .mount("/", routes![hello])
        .mount("/hello", routes![world, mir])
        .mount("/wave", routes![wave])
        .attach(AdHoc::on_request("Compatibility Normalizer", |req, _| Box::pin(async move {
            if !req.uri().is_normalized_nontrailing() {
                let normal = req.uri().clone().into_normalized_nontrailing();
                warn!("Incoming request URI was normalized for compatibility.");
                info_!("{} -> {}", req.uri(), normal);
                req.set_uri(normal);
            }
        })))

}

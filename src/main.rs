use axum::{routing::get, Router};
use std::net::SocketAddr;

async fn health() -> &'static str {
    "ok"
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(health))
        .route("/health", get(health));

    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    println!("Listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

//! Stamps the commit this binary was built from and links the Switch's wrapper functions.

fn main() {
    benilla_buildstamp::emit();
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("horizon") {
        println!("cargo:rustc-link-arg-bins=-Wl,--wrap=nvGpuChannelKickoff");
        println!("cargo:rustc-link-arg-bins=-Wl,--wrap=pthread_atfork");
        println!("cargo:rustc-link-arg-bins=-Wl,--wrap=__syscall_thread_create");
    }
}

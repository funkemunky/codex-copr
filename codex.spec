%bcond_without check
%bcond_without bootstrap
%global cargo_install_lib 0
%global crate_dir codex-rs/cli
%{!?bash_completions_dir:%global bash_completions_dir %{_datadir}/bash-completion/completions}
%{!?fish_completions_dir:%global fish_completions_dir %{_datadir}/fish/vendor_completions.d}
%{!?zsh_completions_dir:%global zsh_completions_dir %{_datadir}/zsh/site-functions}
%if 0%{?fedora}
%global has_fedora_macros 1
%else
%global has_fedora_macros 0
%endif

Name:           codex
Version:        0.98.0
Release:        7
Summary:        OpenAI Codex command-line interface

License:        Apache-2.0
URL:            https://github.com/openai/codex
Source0:        %{url}/archive/refs/tags/rust-v%{version}.tar.gz

%if %{has_fedora_macros}
BuildRequires:  cargo-rpm-macros >= 24
BuildRequires:  rust-packaging
%endif
BuildRequires:  cargo
BuildRequires:  rust
BuildRequires:  pkgconfig(openssl)
BuildRequires:  git-core

%description
OpenAI Codex is a coding assistant that runs in your terminal.

%if %{has_fedora_macros}
%if %{without bootstrap}
%generate_buildrequires
cd %{crate_dir}
%cargo_generate_buildrequires
%endif
%endif

%prep
%autosetup -n codex-rust-v%{version}
cd %{crate_dir}

%if %{has_fedora_macros}
%if %{with bootstrap}
# Bootstrap pulls crates from the network with mock --enable-network
# because not all dependencies exist as Fedora crate RPMs yet
%cargo_prep -N
sed -i 's/offline = true/offline = false/' .cargo/config.toml
%else
%cargo_prep
%endif
%else
%if %{with bootstrap}
# Allow online crate fetches when bootstrap builds are requested.
sed -i 's/offline = true/offline = false/' .cargo/config.toml || :
%endif
%endif

%build
cd %{crate_dir}
%if %{has_fedora_macros}
%cargo_build
%else
%set_build_flags
export CARGO_HOME=$PWD/.cargo-home
mkdir -p "$CARGO_HOME"
export RUSTFLAGS="%{?build_rustflags} -C debuginfo=2"
cargo build --release
%endif

%install
cd %{crate_dir}
%if %{has_fedora_macros}
%cargo_install
%else
install -Dpm 0755 ../target/release/codex %{buildroot}%{_bindir}/codex
%endif

# Shell completion files are generated from the built binary.
%{buildroot}%{_bindir}/codex completion bash > codex.bash
%{buildroot}%{_bindir}/codex completion fish > codex.fish
%{buildroot}%{_bindir}/codex completion zsh > _codex

install -Dpm 0644 codex.bash %{buildroot}%{bash_completions_dir}/codex
install -Dpm 0644 codex.fish %{buildroot}%{fish_completions_dir}/codex.fish
install -Dpm 0644 _codex %{buildroot}%{zsh_completions_dir}/_codex

%check
%{buildroot}%{_bindir}/codex --help >/dev/null
# Cargo tests cause build machine timeout (5h) TODO

%files
%license LICENSE
%doc codex-rs/README.md
%{_bindir}/codex
%{bash_completions_dir}/codex
%{fish_completions_dir}/codex.fish
%{zsh_completions_dir}/_codex

%changelog
* Thu Feb 12 2026 Ernesto Martinez <me@ecomaikgolf.com> - 0.98.0-7
- Define fallback shell completion directory macros for non-Fedora chroots.

* Wed Feb 11 2026 Ernesto Martinez <me@ecomaikgolf.com> - 0.98.0-4
- Gate Fedora Rust macros to Fedora; use plain cargo flow on EL-like chroots.

* Wed Feb 11 2026 Ernesto Martinez <me@ecomaikgolf.com> - 0.98.0-1
- Maintain explicit changelog entry for wider chroot compatibility.

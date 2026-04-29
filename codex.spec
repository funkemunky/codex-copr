%global up_version %{?up_version}%{!?up_version:0}
%global debug_package %{nil}
%global _build_id_links none
%{!?bash_completions_dir:%global bash_completions_dir %{_datadir}/bash-completion/completions}
%{!?fish_completions_dir:%global fish_completions_dir %{_datadir}/fish/vendor_completions.d}
%{!?zsh_completions_dir:%global zsh_completions_dir %{_datadir}/zsh/site-functions}

Name:           codex
Version:        %{up_version}
Release:        1%{?dist}
Summary:        OpenAI Codex command-line interface

License:        Apache-2.0
URL:            https://github.com/openai/codex
Source0:        %{name}-%{version}-x86_64-unknown-linux-musl.tar.gz
Source1:        %{name}-%{version}-aarch64-unknown-linux-musl.tar.gz

ExclusiveArch:  x86_64 aarch64
Requires:       git

%description
OpenAI Codex is a coding assistant that runs in your terminal.

%prep
%setup -q -c -T
%ifarch x86_64
tar -xzf %{SOURCE0} --strip-components=1
%endif
%ifarch aarch64
tar -xzf %{SOURCE1} --strip-components=1
%endif

%build

%install
install -Dpm 0755 codex %{buildroot}%{_bindir}/codex

# Generate shell completions from the packaged binary so the payload stays
# aligned with the shipped CLI.
%{buildroot}%{_bindir}/codex completion bash > codex.bash
%{buildroot}%{_bindir}/codex completion fish > codex.fish
%{buildroot}%{_bindir}/codex completion zsh > _codex

install -Dpm 0644 codex.bash %{buildroot}%{bash_completions_dir}/codex
install -Dpm 0644 codex.fish %{buildroot}%{fish_completions_dir}/codex.fish
install -Dpm 0644 _codex %{buildroot}%{zsh_completions_dir}/_codex

%check
%{buildroot}%{_bindir}/codex --version >/dev/null

%files
%license LICENSE
%doc README.md
%{_bindir}/codex
%{bash_completions_dir}/codex
%{fish_completions_dir}/codex.fish
%{zsh_completions_dir}/_codex

%changelog
* Wed Apr 29 2026 Codex <codex@example.invalid> - 0-1
- Package the latest upstream musl release tarball as an RPM.

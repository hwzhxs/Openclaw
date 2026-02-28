'use client';

export default function Footer() {
  return (
    <footer className="border-t border-border px-6 py-12">
      <div className="mx-auto max-w-[1200px] flex flex-col items-center gap-4 text-center">
        <div className="flex items-center gap-6">
          <span className="text-xs font-semibold uppercase tracking-[0.08em] text-text-muted">DreamTeam</span>
          <span className="text-text-muted/30">·</span>
          {[
            { label: 'GitHub', href: 'https://github.com/openclaw/openclaw' },
            { label: 'Docs', href: 'https://docs.openclaw.ai' },
            { label: 'Discord', href: 'https://discord.com/invite/clawd' },
          ].map((link) => (
            <a
              key={link.label}
              href={link.href}
              target="_blank"
              rel="noopener noreferrer"
              className="text-[13px] text-text-muted transition-colors duration-200 hover:text-text-secondary"
            >
              {link.label}
            </a>
          ))}
        </div>
        <p className="text-[11px] text-text-muted/40">© 2026</p>
      </div>
    </footer>
  );
}

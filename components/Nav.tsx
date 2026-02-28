'use client';

import { useState, useEffect } from 'react';

export default function Nav() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 flex h-16 items-center justify-between px-6 transition-colors duration-300 md:px-12 lg:px-16 ${
        scrolled ? 'bg-[rgba(10,10,10,0.8)] backdrop-blur-xl' : ''
      }`}
    >
      <span className="text-sm font-semibold uppercase tracking-[0.12em] text-text-primary">
        DreamTeam
      </span>
      <nav className="flex items-center gap-8">
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
            className="text-sm text-text-secondary transition-colors duration-200 hover:text-text-primary"
          >
            {link.label}
          </a>
        ))}
      </nav>
    </header>
  );
}

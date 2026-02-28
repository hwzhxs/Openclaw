export default function NotFound() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h1 className="font-serif italic text-6xl text-text-primary">404</h1>
        <p className="mt-4 text-text-secondary">Page not found.</p>
        <a
          href="/"
          className="mt-8 inline-block text-sm text-text-muted transition-colors hover:text-text-primary"
        >
          ← Back home
        </a>
      </div>
    </div>
  );
}

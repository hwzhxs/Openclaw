'use client';

import { useEffect, useRef, useState } from 'react';

export default function Cursor() {
  const ringRef = useRef<HTMLDivElement>(null);
  const dotRef = useRef<HTMLDivElement>(null);
  const trailsRef = useRef<HTMLDivElement[]>([]);
  const posRef = useRef({ x: -200, y: -200 });
  const ringPosRef = useRef({ x: -200, y: -200 });
  const [isHovering, setIsHovering] = useState(false);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    // Only on pointer:fine devices
    if (window.matchMedia('(pointer: coarse)').matches) return;

    const TRAIL_COUNT = 6;

    const onMove = (e: MouseEvent) => {
      posRef.current = { x: e.clientX, y: e.clientY };
      if (!isVisible) setIsVisible(true);

      // Dot snaps immediately
      if (dotRef.current) {
        dotRef.current.style.transform = `translate(${e.clientX}px, ${e.clientY}px) translate(-50%, -50%)`;
      }
    };

    const onEnter = (e: MouseEvent) => {
      const t = e.target as HTMLElement;
      if (t.closest('a, button, [data-cursor-hover], input, textarea, select')) {
        setIsHovering(true);
      }
    };

    const onLeave = (e: MouseEvent) => {
      const t = e.target as MouseEvent['target'] & HTMLElement;
      if (t.closest && t.closest('a, button, [data-cursor-hover], input, textarea, select')) {
        setIsHovering(false);
      }
    };

    window.addEventListener('mousemove', onMove);
    window.addEventListener('mouseover', onEnter);
    window.addEventListener('mouseout', onLeave);

    // Animate ring with lerp
    let rafId: number;
    function animate() {
      const rx = ringPosRef.current.x;
      const ry = ringPosRef.current.y;
      const tx = posRef.current.x;
      const ty = posRef.current.y;

      const nx = rx + (tx - rx) * 0.12;
      const ny = ry + (ty - ry) * 0.12;
      ringPosRef.current = { x: nx, y: ny };

      if (ringRef.current) {
        ringRef.current.style.transform = `translate(${nx}px, ${ny}px) translate(-50%, -50%)`;
      }

      // Animate trails with increasing lag
      trailsRef.current.forEach((el, i) => {
        if (!el) return;
        const lag = 0.08 - i * 0.01;
        const ex = parseFloat(el.dataset.x || String(nx));
        const ey = parseFloat(el.dataset.y || String(ny));
        const nnx = ex + (tx - ex) * lag;
        const nny = ey + (ty - ey) * lag;
        el.dataset.x = String(nnx);
        el.dataset.y = String(nny);
        el.style.transform = `translate(${nnx}px, ${nny}px) translate(-50%, -50%)`;
        const alpha = (1 - i / TRAIL_COUNT) * 0.25;
        el.style.opacity = String(alpha);
      });

      rafId = requestAnimationFrame(animate);
    }
    rafId = requestAnimationFrame(animate);

    return () => {
      window.removeEventListener('mousemove', onMove);
      window.removeEventListener('mouseover', onEnter);
      window.removeEventListener('mouseout', onLeave);
      cancelAnimationFrame(rafId);
    };
  }, [isVisible]);

  const TRAIL_COUNT = 6;

  if (typeof window !== 'undefined' && window.matchMedia('(pointer: coarse)').matches) {
    return null;
  }

  return (
    <>
      {/* Trail dots */}
      {Array.from({ length: TRAIL_COUNT }).map((_, i) => (
        <div
          key={i}
          ref={el => { if (el) trailsRef.current[i] = el; }}
          className="pointer-events-none fixed top-0 left-0 z-[9998] rounded-full"
          style={{
            width: 8 - i * 0.8,
            height: 8 - i * 0.8,
            background: `rgba(196, 154, 26, 0.6)`,
            opacity: 0,
            willChange: 'transform',
          }}
        />
      ))}

      {/* Outer ring — lags behind */}
      <div
        ref={ringRef}
        className="pointer-events-none fixed top-0 left-0 z-[9999] rounded-full transition-[width,height,background,border-color] duration-200"
        style={{
          width: isHovering ? 56 : 40,
          height: isHovering ? 56 : 40,
          border: `1.5px solid ${isHovering ? 'rgba(196,154,26,0.9)' : 'rgba(196,154,26,0.5)'}`,
          background: isHovering ? 'rgba(196,154,26,0.08)' : 'transparent',
          boxShadow: isHovering
            ? '0 0 20px rgba(196,154,26,0.3), inset 0 0 20px rgba(196,154,26,0.05)'
            : '0 0 12px rgba(196,154,26,0.15)',
          willChange: 'transform',
          opacity: isVisible ? 1 : 0,
        }}
      />

      {/* Inner dot — snaps */}
      <div
        ref={dotRef}
        className="pointer-events-none fixed top-0 left-0 z-[9999] rounded-full transition-[width,height] duration-150"
        style={{
          width: isHovering ? 6 : 5,
          height: isHovering ? 6 : 5,
          background: 'rgba(196, 154, 26, 1)',
          boxShadow: '0 0 8px rgba(196,154,26,0.8)',
          willChange: 'transform',
          opacity: isVisible ? 1 : 0,
        }}
      />
    </>
  );
}

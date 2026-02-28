'use client';

import { useRef, useEffect, useState } from 'react';

interface SplitTextProps {
  text: string;
  className?: string;
  delay?: number;
  animationFrom?: { opacity?: number; transform?: string };
  animationTo?: { opacity?: number; transform?: string };
  easing?: string;
  threshold?: number;
  rootMargin?: string;
  animateBy?: 'chars' | 'words';
}

// Simple easing map
const easingMap: Record<string, string> = {
  easeOutCubic: 'cubic-bezier(0.33, 1, 0.68, 1)',
  easeOut: 'ease-out',
  easeIn: 'ease-in',
  easeInOut: 'ease-in-out',
  linear: 'linear',
};

export default function SplitText({
  text,
  className = '',
  delay = 50,
  animationFrom = { opacity: 0, transform: 'translateY(20px)' },
  animationTo = { opacity: 1, transform: 'translateY(0)' },
  easing = 'easeOutCubic',
  threshold = 0.1,
  rootMargin = '-50px',
  animateBy = 'chars',
}: SplitTextProps) {
  const containerRef = useRef<HTMLSpanElement>(null);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
          obs.disconnect();
        }
      },
      { threshold, rootMargin }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [threshold, rootMargin]);

  const easingCss = easingMap[easing] ?? easing;

  const units = animateBy === 'words' ? text.split(' ') : text.split('');

  return (
    <span ref={containerRef} className={className} aria-label={text}>
      {units.map((unit, i) => {
        const isSpace = unit === ' ';
        const displayUnit = animateBy === 'words' ? (i < units.length - 1 ? unit + '\u00A0' : unit) : (isSpace ? '\u00A0' : unit);

        const fromOpacity = animationFrom.opacity ?? 0;
        const toOpacity = animationTo.opacity ?? 1;
        const fromTransform = animationFrom.transform ?? 'translateY(20px)';
        const toTransform = animationTo.transform ?? 'translateY(0)';

        return (
          <span
            key={i}
            className="inline-block overflow-hidden"
            style={animateBy === 'chars' ? undefined : { whiteSpace: 'pre' }}
          >
            <span
              className="inline-block"
              style={{
                opacity: isVisible ? toOpacity : fromOpacity,
                transform: isVisible ? toTransform : fromTransform,
                transition: isVisible
                  ? `opacity 0.55s ${easingCss} ${i * delay}ms, transform 0.55s ${easingCss} ${i * delay}ms`
                  : 'none',
                whiteSpace: isSpace ? 'pre' : undefined,
              }}
            >
              {displayUnit}
            </span>
          </span>
        );
      })}
    </span>
  );
}

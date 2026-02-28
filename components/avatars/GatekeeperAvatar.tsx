'use client';

import { motion } from 'framer-motion';

/** Gatekeeper — Hexagonal shield matrix */
export default function GatekeeperAvatar({ size = 120 }: { size?: number }) {
  // Hexagon helper
  const hex = (cx: number, cy: number, r: number) => {
    const pts = [];
    for (let i = 0; i < 6; i++) {
      const angle = (Math.PI / 3) * i - Math.PI / 6;
      pts.push(`${cx + r * Math.cos(angle)},${cy + r * Math.sin(angle)}`);
    }
    return pts.join(' ');
  };

  const hexagons = [
    { cx: 60, cy: 45, r: 16, delay: 0 },
    { cx: 42, cy: 60, r: 12, delay: 0.2 },
    { cx: 78, cy: 60, r: 12, delay: 0.4 },
    { cx: 50, cy: 78, r: 10, delay: 0.6 },
    { cx: 70, cy: 78, r: 10, delay: 0.8 },
  ];

  return (
    <motion.svg
      width={size}
      height={size}
      viewBox="0 0 120 120"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      whileHover={{ scale: 1.1 }}
      transition={{ type: 'spring', stiffness: 200 }}
    >
      {/* Shield glow */}
      <motion.circle
        cx="60"
        cy="62"
        r="42"
        fill="url(#gkGlow)"
        animate={{ opacity: [0.15, 0.3, 0.15] }}
        transition={{ duration: 3, repeat: Infinity }}
      />

      {/* Hexagons */}
      {hexagons.map((h, i) => (
        <motion.polygon
          key={i}
          points={hex(h.cx, h.cy, h.r)}
          fill={`url(#gkHex${i})`}
          stroke="#EF4444"
          strokeWidth="1.5"
          animate={{
            opacity: [0.4, 0.9, 0.4],
            strokeWidth: [1.5, 2, 1.5],
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
            delay: h.delay,
            ease: 'easeInOut',
          }}
        />
      ))}

      {/* Lock icon in center hex */}
      <motion.path
        d="M56,42 L56,38 A4,4 0 0 1 64,38 L64,42 M54,42 L66,42 L66,52 L54,52 Z"
        fill="none"
        stroke="#EF4444"
        strokeWidth="1.5"
        animate={{ opacity: [0.6, 1, 0.6] }}
        transition={{ duration: 2, repeat: Infinity }}
      />

      {/* Defensive pulse */}
      <motion.circle
        cx="60"
        cy="62"
        r="35"
        fill="none"
        stroke="#EF4444"
        strokeWidth="1"
        animate={{ r: [35, 48, 35], opacity: [0.3, 0, 0.3] }}
        transition={{ duration: 3, repeat: Infinity }}
      />

      <defs>
        <radialGradient id="gkGlow" cx="0.5" cy="0.5" r="0.5">
          <stop offset="0%" stopColor="#EF4444" stopOpacity="0.25" />
          <stop offset="100%" stopColor="#EF4444" stopOpacity="0" />
        </radialGradient>
        {hexagons.map((_, i) => (
          <linearGradient key={i} id={`gkHex${i}`} x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#EF4444" stopOpacity={0.15 + i * 0.05} />
            <stop offset="100%" stopColor="#DC2626" stopOpacity={0.05} />
          </linearGradient>
        ))}
      </defs>
    </motion.svg>
  );
}

'use client';

import { motion } from 'framer-motion';

/** Admin — Radar pulse / command star */
export default function AdminAvatar({ size = 120 }: { size?: number }) {
  return (
    <motion.svg
      width={size}
      height={size}
      viewBox="0 0 120 120"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      whileHover={{ scale: 1.1, rotate: 15 }}
      transition={{ type: 'spring', stiffness: 200 }}
    >
      {/* Outer pulse rings */}
      {[1, 2, 3].map((ring) => (
        <motion.circle
          key={ring}
          cx="60"
          cy="60"
          r={20 + ring * 12}
          stroke="#3B82F6"
          strokeWidth="1"
          fill="none"
          opacity={0.3 / ring}
          animate={{
            r: [20 + ring * 12, 24 + ring * 12, 20 + ring * 12],
            opacity: [0.3 / ring, 0.5 / ring, 0.3 / ring],
          }}
          transition={{ duration: 2 + ring * 0.5, repeat: Infinity, ease: 'easeInOut' }}
        />
      ))}

      {/* Star shape */}
      <motion.polygon
        points="60,20 68,45 95,45 73,60 80,85 60,70 40,85 47,60 25,45 52,45"
        fill="url(#adminGrad)"
        stroke="#3B82F6"
        strokeWidth="1.5"
        animate={{ rotate: [0, 360] }}
        transition={{ duration: 30, repeat: Infinity, ease: 'linear' }}
        style={{ transformOrigin: '60px 60px' }}
      />

      {/* Center dot */}
      <motion.circle
        cx="60"
        cy="55"
        r="4"
        fill="#3B82F6"
        animate={{ opacity: [1, 0.4, 1], scale: [1, 1.3, 1] }}
        transition={{ duration: 1.5, repeat: Infinity }}
      />

      {/* Scan line */}
      <motion.line
        x1="60"
        y1="55"
        x2="60"
        y2="20"
        stroke="#3B82F6"
        strokeWidth="1.5"
        opacity={0.6}
        animate={{ rotate: [0, 360] }}
        transition={{ duration: 3, repeat: Infinity, ease: 'linear' }}
        style={{ transformOrigin: '60px 55px' }}
      />

      <defs>
        <linearGradient id="adminGrad" x1="25" y1="20" x2="95" y2="85">
          <stop offset="0%" stopColor="#3B82F6" stopOpacity="0.8" />
          <stop offset="100%" stopColor="#1D4ED8" stopOpacity="0.3" />
        </linearGradient>
      </defs>
    </motion.svg>
  );
}

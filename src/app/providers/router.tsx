import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { HomePage } from '@/pages/home';
import { LoginPage } from '@/pages/login';
import { SignupPage } from '@/pages/signup';
import ResetPasswordPage from '@/pages/reset-password';
import ForgotPasswordPage from '@/pages/forgot-password';

const router = createBrowserRouter([
  {
    path: '/',
    element: <HomePage />,
  },
  // Auth routes
  {
    path: '/auth/login',
    element: <LoginPage />,
  },
  {
    path: '/auth/signup',
    element: <SignupPage />,
  },
  {
    path: '/auth/forgot-password',
    element: <ForgotPasswordPage />,
  },
  {
    path: '/auth/reset-password',
    element: <ResetPasswordPage />,
  },
  // Legacy redirects for backward compatibility
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/signup',
    element: <SignupPage />,
  },
]);

export function Router() {
  return <RouterProvider router={router} />;
}

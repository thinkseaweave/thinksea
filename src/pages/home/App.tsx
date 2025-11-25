import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import reactLogo from '@/shared/assets/react.svg'
import viteLogo from '/vite.svg'
import '@/app/styles/App.css'
import { Button, ModeToggle } from "@/shared/ui"
import { authApi, type User } from '@/entities/user'

function App() {
  const [count, setCount] = useState(0)
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const navigate = useNavigate()

  useEffect(() => {
    // 현재 사용자 확인
    const checkUser = async () => {
      try {
        const currentUser = await authApi.getCurrentUser()
        setUser(currentUser)
      } catch {
        setUser(null)
      } finally {
        setIsLoading(false)
      }
    }

    checkUser()

    // Auth 상태 변화 구독
    const { data: { subscription } } = authApi.onAuthStateChange((currentUser) => {
      setUser(currentUser)
    })

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  const handleLogout = async () => {
    try {
      await authApi.signOut()
      setUser(null)
      navigate('/auth/login')
    } catch (error) {
      console.error('Logout failed:', error)
    }
  }

  return (
    <>
      <div className="absolute top-4 right-4 flex gap-2 items-center">
        <ModeToggle />
        {isLoading ? (
          <Button disabled>로딩 중...</Button>
        ) : user ? (
          <>
            <span className="text-sm text-gray-700 dark:text-gray-300">
              {user.email}
            </span>
            <Button onClick={handleLogout}>
              로그아웃
            </Button>
          </>
        ) : (
          <>
            <Link to="/auth/login">
              <Button>로그인</Button>
            </Link>
            <Link to="/auth/signup">
              <Button>회원가입</Button>
            </Link>
          </>
        )}
      </div>
      <div>
        <a href="https://vite.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="card">
        <Button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </Button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  )
}

export default App

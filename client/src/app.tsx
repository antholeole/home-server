import { useCallback, useEffect, useState } from 'react'
import { type Platform, platform } from '@tauri-apps/api/os'
import { Route, Switch } from 'wouter'

import { clsx } from 'clsx'

export default function App() {
  const [osType, setOsType] = useState<Platform>('darwin')

  const fetchOsType = useCallback(async () => {
    setOsType(await platform())
  }, [])

  useEffect(() => {
    fetchOsType()
  }, [fetchOsType])

  return (
    <div className={clsx('disable-select')}>

      <p>hi</p>
      {/* <Switch>
        <Route path='/'>
          <WelcomeScreen />
        </Route>
        <Route path='/settings'>
          <SettingScreen />
        </Route>
        <Route>
          <NotFoundScreen />
        </Route>
      </Switch> */}
    </div>
  )
}

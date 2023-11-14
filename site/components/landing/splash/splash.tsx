import Image from 'next/image'
import { RotatingText } from './components/rotating_text/rotating_text'
import { Cards } from './components/cards/cards'
import SplashStyles from './splash.module.scss'

// the words to put in the rotation
const words = [
  'Work Team.',
  'School Club.',
  'Sports Team.',
  'Extracurricular.',
]

export const Splash = (): JSX.Element => (
  <>
    <section className={SplashStyles.splash}>
      <div className={SplashStyles.copy}>
        <p>
          The Best Way to Manage a
        </p>
        <h1>
          <RotatingText words={words} />
        </h1>
        <Cards />
      </div>
      <div className={SplashStyles.image}>
        <Image
          className={SplashStyles.phone}
          alt="Phone with Club App load screen"
          src="/phone.png"
          width={500}
          height={500}
        />
      </div>
    </section>
  </>
)

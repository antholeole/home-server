import {
  createRef, RefObject, useEffect, useState,
} from 'react'
import { multiclass } from '../../../../../utils/class'
import { useInterval } from '../../../../../utils/use_interval'
import RotatingTextStyle from './rotating_text.module.scss'

// eslint-disable-next-line no-shadow
enum LetterState {
  Out = 1,
  In,
  Behind,
  None
}

interface ILetter {
  ref: RefObject<HTMLSpanElement>,
  state: LetterState
}
interface IWord {
  word: string,
  ref: RefObject<HTMLSpanElement>,
  visible: boolean,
  letters: ILetter[]
}

interface IRotatingTextProps {
  // the words to put into rotation
  words: string[],
   // how long to wait before dropping in the new word
  spacing?: number,
  // how long each letter waits for the last
  letterTime?: number,
  // how long a word is shown before rotating
  rotationSpeed?: number
}

const spacingDefault = 340
const letterTimeDefault = 80
const rotationSpeedDefault = 10000

export const RotatingText = ({
  words, spacing, letterTime, rotationSpeed,
}: IRotatingTextProps): JSX.Element => {
  const [currWordIndex, setCurrWordIndex] = useState(0)
  const [wordRefs, setWordRefs] = useState<IWord[]>(
    Array(words.length).fill(undefined).map((_, i) => ({
      word: words[i],
      ref: createRef<HTMLSpanElement>(),
      visible: false,
      letters: Array(words[i].length).fill(undefined).map(() => ({
        state: LetterState.None,
        ref: createRef<HTMLSpanElement>(),
      })),
    })),
  )

  const updateWordRef = (index: number, word: Partial<IWord>) => {
    setWordRefs((oldWordRefs) => [
      ...oldWordRefs.slice(0, index),
      {
        ...oldWordRefs[index],
        ...word,
      },
      ...oldWordRefs.slice(index + 1),
    ])
  }

  const updateLetterRef = (wordIndex: number, letterIndex: number, letter: Partial<ILetter>) => {
    setWordRefs((oldWordRefs) => [
      ...oldWordRefs.slice(0, wordIndex),
      {
        ...oldWordRefs[wordIndex],
        letters: [
          ...oldWordRefs[wordIndex].letters.slice(0, letterIndex),
          {
            ...oldWordRefs[wordIndex].letters[letterIndex],
            ...letter,
          },
          ...oldWordRefs[wordIndex].letters.slice(letterIndex + 1),
        ],
      },
      ...oldWordRefs.slice(wordIndex + 1),
    ])
  }

  const animateLetterOut = (wordIndex: number, letterIndex: number) => {
    setTimeout(() => {
      updateLetterRef(wordIndex, letterIndex, {
        state: LetterState.Out,
      })
    }, letterIndex * (letterTime ?? letterTimeDefault))
  }

  const animateLetterIn = (wordIndex: number, letterIndex: number) => {
    setTimeout(() => {
      updateLetterRef(wordIndex, letterIndex, {
        state: LetterState.In,
      })
    }, (spacing ?? spacingDefault) + (letterIndex * (letterTime ?? letterTimeDefault)))
  }

  const determineLetterClass = (state: LetterState, letter: string): string => {
    const classes = ['letter']

    if (letter === ' ') {
      classes.push('space')
    }

    switch (state) {
      case LetterState.Behind:
        classes.push('behind')
        break
      case LetterState.In:
        classes.push('in')
        break
      case LetterState.Out:
        classes.push('out')
        break
      default:
        break
    }

    return multiclass(RotatingTextStyle, ...classes)
  }

  const changeWord = () => {
    const currWord = wordRefs[currWordIndex]
    const nextWordIndex = currWordIndex === words.length - 1 ? 0 : currWordIndex + 1
    const nextWord = wordRefs[nextWordIndex]

    currWord.letters.forEach((_, letterIndex) => animateLetterOut(currWordIndex, letterIndex))

    updateWordRef(nextWordIndex, { visible: true })
    nextWord.letters.forEach((_, letterIndex) => {
      updateLetterRef(nextWordIndex, letterIndex, {
        state: LetterState.Behind,
      })

      animateLetterIn(nextWordIndex, letterIndex)
    })

    setCurrWordIndex((currWordIndex === words.length - 1) ? 0 : currWordIndex + 1)
  }

  useEffect(changeWord, [])
  useInterval(changeWord, rotationSpeed ?? rotationSpeedDefault)

  return (
    <>
      {wordRefs.map((word, wordIndex) => (
        <span
          key={word.word}
          className={RotatingTextStyle.word}
          style={{ opacity: word.visible ? 1 : 0 }}
        >
          {word.letters.map((letter, letterIndex) => (
            <span
                // optimized: letter indicies never changes
                // eslint-disable-next-line react/no-array-index-key
              key={`${word.word}-${letterIndex}`}
              className={
                    determineLetterClass(letter.state, wordRefs[wordIndex].word[letterIndex])
                    }
            >
              {wordRefs[wordIndex].word[letterIndex]}
            </span>
          ))}
        </span>
      ))}
    </>
  )
}

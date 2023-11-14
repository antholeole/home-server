import { Calendar } from '@styled-icons/ionicons-outline/Calendar'
import { ChatbubbleEllipses } from '@styled-icons/ionicons-outline/ChatbubbleEllipses'
import { Checkmark } from '@styled-icons/ionicons-outline/Checkmark'
import CardStyles from './cards.module.scss'

interface CardProps {
  header: string,
  body: string,
  icon: JSX.Element
}

export const Cards = () => {
  const Card = ({ header, body, icon }: CardProps): JSX.Element => (
    <div className={CardStyles.card}>
      <div className={CardStyles.icon}>
        {icon}
      </div>
      <div className={CardStyles.copy}>
        <h3>{header}</h3>
        <p>
          {body}
        </p>
      </div>
    </div>
  )

  return (
    <div className={CardStyles.trifold}>
      <Card
        header="Schedule Events"
        body="Schedule reoccuring or one-time events. Then, send reminders by notification."
        icon={<Calendar />}
      />
      <Card
        header="Keep Constant Communication"
        body="Create threads with as many people as you need, or 1-on-1 direct messages."
        icon={<ChatbubbleEllipses />}
      />
      <Card
        header="All the Other Features you Expect."
        body="Send images, tag members, and react to messages."
        icon={<Checkmark />}
      />
    </div>
  )
}

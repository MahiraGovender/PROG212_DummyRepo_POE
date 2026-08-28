# RaceDay

## System Description

RaceDay is a full-stack, web-based event management system designed for the South African road running, walking, and cycling community.

South Africa has a strong road events culture, with major events such as the Comrades Marathon, Cape Town Cycle Tour, Soweto Marathon and Two Oceans, as well as numerous community walks, park runs and charity cycling events. However, many events can still rely on paper-based registration, spreadsheets and disconnected communication, which can make managing participants and event information difficult.

RaceDay aims to provide a centralised platform for managing these events digitally. Event Organisers can create and manage events, define event categories, manage participant enrolments and capture race results. Participants can browse upcoming events, enter events by selecting their desired categories, view their enrolments and track their personal results.

The system is being developed as an API-driven application using modern software development practices, with continuous integration and deployment processes supported through GitHub Actions.

## User Roles

RaceDay supports two distinct user roles:

### Organiser

The **Organiser** is responsible for managing road running, walking and cycling events through the system. Organisers can:

- Create events.
- Edit existing events.
- Delete events.
- Define age or distance categories for events.
- View participant enrolments for their events.
- Capture participant finishing times and positions.
- Manage participant results.

### Participant

The **Participant** uses RaceDay to discover and participate in events. Participants can:

- Create an account.
- Log in to the system.
- Browse upcoming events.
- View event information and available categories.
- Enter an event by selecting one or more categories.
- View their own event enrolments.
- View and track their personal race results.

## CI/CD

The project uses **GitHub Actions** to automate repository validation and support the project's CI/CD workflow.

The GitHub Actions workflow validates the required repository structure and checks that the required documentation files are present in the `/docs` folder.

### CI/CD Workflow Screenshot

<img width="1910" height="1060" alt="CI_Pipeline_PNG" src="https://github.com/user-attachments/assets/ba7e2416-a7d7-418b-9916-6bc94c91d956" />

## Project Documentation

Additional project documentation can be found in the `/docs` folder, including:

- API Endpoint Plan
- Entity Relationship Diagram (ERD)
- SQL Database Script

## YouTube Link:

[Explanation video](YOUTUBE_VIDEO_LINK_HERE)

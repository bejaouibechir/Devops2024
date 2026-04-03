import { Component } from 'react'

export default class ErrorBoundary extends Component {
  state = { hasError: false, error: null }

  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex flex-col items-center justify-center py-16 gap-4 text-center">
          <div className="text-5xl">⚠️</div>
          <h2 className="text-xl font-semibold text-gray-800">Une erreur est survenue</h2>
          <p className="text-sm text-gray-500 max-w-md">{this.state.error?.message}</p>
          <button
            className="btn-primary"
            onClick={() => this.setState({ hasError: false, error: null })}
          >
            Réessayer
          </button>
        </div>
      )
    }
    return this.props.children
  }
}
